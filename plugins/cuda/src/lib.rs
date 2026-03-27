#[macro_use]
extern crate kheavyhash_miner;

use clap::{ArgMatches, FromArgMatches};
use cust::prelude::*;
use kheavyhash_miner::{Plugin, Worker, WorkerSpec};
use log::LevelFilter;
use std::error::Error as StdError;
#[cfg(feature = "overclock")]
use {
    log::{error, info, warn},
    nvml_wrapper::Device as NvmlDevice,
    nvml_wrapper::Nvml,
};

pub type Error = Box<dyn StdError + Send + Sync + 'static>;

mod cli;
mod worker;

use crate::cli::{CudaOpt, NonceGenEnum};
use crate::worker::CudaGPUWorker;

const DEFAULT_WORKLOAD_SCALE: f32 = 1024.;

pub struct CudaPlugin {
    specs: Vec<CudaWorkerSpec>,
    #[cfg(feature = "overclock")]
    nvml_instance: Option<Nvml>,
    _enabled: bool,
}

impl CudaPlugin {
    fn new() -> Result<Self, Error> {
        cust::init(CudaFlags::empty())?;
        env_logger::builder().filter_level(LevelFilter::Info).parse_default_env().init();
        Ok(Self {
            specs: Vec::new(),
            _enabled: false,
            #[cfg(feature = "overclock")]
            nvml_instance: None,
        })
    }
}

impl Plugin for CudaPlugin {
    fn name(&self) -> &'static str {
        "CUDA Worker"
    }

    fn enabled(&self) -> bool {
        self._enabled
    }

    fn get_worker_specs(&self) -> Vec<Box<dyn WorkerSpec>> {
        self.specs.iter().map(|spec| Box::new(*spec) as Box<dyn WorkerSpec>).collect::<Vec<Box<dyn WorkerSpec>>>()
    }

    //noinspection RsTypeCheck
    fn process_option(&mut self, matches: &ArgMatches) -> Result<usize, kheavyhash_miner::Error> {
        let opts: CudaOpt = CudaOpt::from_arg_matches(matches)?;

        self._enabled = !opts.cuda_disable;
        if self._enabled {
            let num_devices = match Device::num_devices() {
                Ok(n) => n as u16,
                Err(e) => {
                    self._enabled = false;
                    return Err(format!(
                        "CUDA is not usable ({}). No NVIDIA GPU, driver, or working CUDA runtime. \
                         Pass --cuda-disable if you use CPU/OpenCL only.",
                        e
                    )
                    .into());
                }
            };
            if num_devices == 0 {
                self._enabled = false;
                return Err("No CUDA devices found. Pass --cuda-disable if you use CPU/OpenCL only.".into());
            }

            let gpus: Vec<u16> = match &opts.cuda_device {
                Some(devices) => {
                    for &d in devices {
                        if d >= num_devices {
                            self._enabled = false;
                            return Err(format!(
                                "CUDA device index {} is out of range ({} device(s) available)",
                                d, num_devices
                            )
                            .into());
                        }
                    }
                    devices.clone()
                }
                None => (0..num_devices).collect(),
            };

            // if any of cuda_lock_core_clocks / cuda_lock_mem_clocks / cuda_power_limit is valid, init nvml and try to apply
            #[cfg(feature = "overclock")]
            if opts.overclock.cuda_lock_core_clocks.is_some()
                || opts.overclock.cuda_lock_mem_clocks.is_some()
                || opts.overclock.cuda_power_limits.is_some()
            {
                if self.nvml_instance.is_none() {
                    self.nvml_instance = match Nvml::init() {
                        Ok(nvml) => Some(nvml),
                        Err(e) => {
                            if opts.overclock.overclock_fallback {
                                warn!(
                                    "CUDA overclock requested but NVML initialization failed ({}). \
                                     Continuing without overclock operations due to --overclock-fallback.",
                                    e
                                );
                                None
                            } else {
                                self._enabled = false;
                                return Err(format!(
                                    "CUDA overclock requested, but NVML initialization failed ({}). \
                                     Overclock mode cannot be performed on this system. \
                                     Pass --overclock-fallback to continue without overclock.",
                                    e
                                )
                                .into());
                            }
                        }
                    };
                }

                if let Some(nvml_instance) = self.nvml_instance.as_ref() {
                    for i in 0..gpus.len() {
                        let lock_mem_clock: Option<u32> = match &opts.overclock.cuda_lock_mem_clocks {
                            Some(mem_clocks) if i < mem_clocks.len() => Some(mem_clocks[i]),
                            Some(mem_clocks) if !mem_clocks.is_empty() => Some(*mem_clocks.last().unwrap()),
                            _ => None,
                        };

                        let lock_core_clock: Option<u32> = match &opts.overclock.cuda_lock_core_clocks {
                            Some(core_clocks) if i < core_clocks.len() => Some(core_clocks[i]),
                            Some(core_clocks) if !core_clocks.is_empty() => Some(*core_clocks.last().unwrap()),
                            _ => None,
                        };

                        let power_limit: Option<u32> = match &opts.overclock.cuda_power_limits {
                            Some(power_limits) if i < power_limits.len() => Some(power_limits[i]),
                            Some(power_limits) if !power_limits.is_empty() => Some(*power_limits.last().unwrap()),
                            _ => None,
                        };

                        let mut nvml_device: NvmlDevice = nvml_instance.device_by_index(gpus[i] as u32)?;

                        if let Some(lmc) = lock_mem_clock {
                            match nvml_device.set_mem_locked_clocks(lmc, lmc) {
                                Err(e) => error!("set mem locked clocks {:?}", e),
                                _ => info!("GPU #{} #{} lock mem clock at {} Mhz", i, &nvml_device.name()?, &lmc),
                            };
                        }

                        if let Some(lcc) = lock_core_clock {
                            match nvml_device.set_gpu_locked_clocks(lcc, lcc) {
                                Err(e) => error!("set gpu locked clocks {:?}", e),
                                _ => info!("GPU #{} #{} lock core clock at {} Mhz", i, &nvml_device.name()?, &lcc),
                            };
                        };

                        if let Some(pl) = power_limit {
                            match nvml_device.set_power_management_limit(pl * 1000) {
                                Err(e) => error!("set power limit {:?}", e),
                                _ => info!("GPU #{} #{} power limit at {} W", i, &nvml_device.name()?, &pl),
                            };
                        };
                    }
                } else {
                    info!("Overclock mode enabled without NVML operations; running non-overclock CUDA path.");
                }
            }

            self.specs = (0..gpus.len())
                .map(|i| CudaWorkerSpec {
                    device_id: gpus[i] as u32,
                    workload: match &opts.cuda_workload {
                        Some(workload) if i < workload.len() => workload[i],
                        Some(workload) if !workload.is_empty() => *workload.last().unwrap(),
                        _ => DEFAULT_WORKLOAD_SCALE,
                    },
                    is_absolute: opts.cuda_workload_absolute,
                    blocking_sync: !opts.cuda_no_blocking_sync,
                    random: opts.cuda_nonce_gen,
                })
                .collect();

            // Preflight worker initialization so CUDA/PTX failures are reported gracefully
            // during startup rather than panicking later in worker threads.
            for spec in &self.specs {
                if let Err(e) = CudaGPUWorker::preflight(spec.device_id, spec.blocking_sync) {
                    self._enabled = false;
                    return Err(format!(
                        "Failed to initialize CUDA worker for device #{} ({}). \
                         This is usually a PTX/driver compatibility issue.",
                        spec.device_id, e
                    )
                    .into());
                }
            }
        }
        Ok(self.specs.len())
    }
}

#[derive(Copy, Clone)]
struct CudaWorkerSpec {
    device_id: u32,
    workload: f32,
    is_absolute: bool,
    blocking_sync: bool,
    random: NonceGenEnum,
}

impl WorkerSpec for CudaWorkerSpec {
    fn id(&self) -> String {
        match Device::get_device(self.device_id) {
            Ok(device) => match device.name() {
                Ok(name) => format!("#{} ({})", self.device_id, name),
                Err(_) => format!("#{} (CUDA)", self.device_id),
            },
            Err(_) => format!("#{} (CUDA device unavailable)", self.device_id),
        }
    }

    fn build(&self) -> Box<dyn Worker> {
        Box::new(
            CudaGPUWorker::new(self.device_id, self.workload, self.is_absolute, self.blocking_sync, self.random)
                .unwrap(),
        )
    }
}

declare_plugin!(CudaPlugin, CudaPlugin::new, CudaOpt);
