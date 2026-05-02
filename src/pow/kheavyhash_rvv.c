/* RVV 1.0 helpers for kHeavyHash — compile with -march=rv64gcv (or compatible). */
#include <riscv_vector.h>
#include <stddef.h>
#include <stdint.h>

uint32_t khh_dot_u16_u8_64(const uint16_t *row, const uint8_t *vec, size_t n)
{
	uint32_t sum = 0;
	while (n > 0) {
		size_t vl = __riscv_vsetvl_e16m1(n);
		vuint16m1_t v_row = __riscv_vle16_v_u16m1(row, vl);
		vuint8mf2_t v_u8 = __riscv_vle8_v_u8mf2(vec, vl);
		vuint16m1_t v_z = __riscv_vzext_vf2_u16m1(v_u8, vl);
		vuint32m2_t v_mul = __riscv_vwmulu_vv_u32m2(v_row, v_z, vl);
		vuint32m1_t v_zero = __riscv_vmv_v_x_u32m1(0, vl);
		vuint32m1_t v_part = __riscv_vredsum_vs_u32m2_u32m1(v_mul, v_zero, vl);
		sum += (uint32_t)__riscv_vmv_x_s_u32m1_u32(v_part);
		row += vl;
		vec += vl;
		n -= vl;
	}
	return sum;
}

void khh_dot_pair_u16_u8_64(const uint16_t *row_a, const uint16_t *row_b, const uint8_t *vec,
			     size_t n, uint32_t *out_sum_a, uint32_t *out_sum_b)
{
	uint32_t sum_a = 0;
	uint32_t sum_b = 0;
	while (n > 0) {
		size_t vl = __riscv_vsetvl_e16m1(n);
		vuint16m1_t v_ra = __riscv_vle16_v_u16m1(row_a, vl);
		vuint16m1_t v_rb = __riscv_vle16_v_u16m1(row_b, vl);
		vuint8mf2_t v_u8 = __riscv_vle8_v_u8mf2(vec, vl);
		vuint16m1_t v_z = __riscv_vzext_vf2_u16m1(v_u8, vl);
		vuint32m2_t v_mul_a = __riscv_vwmulu_vv_u32m2(v_ra, v_z, vl);
		vuint32m2_t v_mul_b = __riscv_vwmulu_vv_u32m2(v_rb, v_z, vl);
		vuint32m1_t v_zero_a = __riscv_vmv_v_x_u32m1(0, vl);
		vuint32m1_t v_part_a = __riscv_vredsum_vs_u32m2_u32m1(v_mul_a, v_zero_a, vl);
		vuint32m1_t v_zero_b = __riscv_vmv_v_x_u32m1(0, vl);
		vuint32m1_t v_part_b = __riscv_vredsum_vs_u32m2_u32m1(v_mul_b, v_zero_b, vl);
		sum_a += (uint32_t)__riscv_vmv_x_s_u32m1_u32(v_part_a);
		sum_b += (uint32_t)__riscv_vmv_x_s_u32m1_u32(v_part_b);
		row_a += vl;
		row_b += vl;
		vec += vl;
		n -= vl;
	}
	*out_sum_a = sum_a;
	*out_sum_b = sum_b;
}

void khh_f64_row_scale(double *row, double inv, size_t n)
{
	while (n > 0) {
		size_t vl = __riscv_vsetvl_e64m1(n);
		vfloat64m1_t v = __riscv_vle64_v_f64m1(row, vl);
		v = __riscv_vfmul_vf_f64m1(v, inv, vl);
		__riscv_vse64_v_f64m1(row, v, vl);
		row += vl;
		n -= vl;
	}
}

void khh_f64_row_axpy_sub(double *dst, const double *src, double factor, size_t n)
{
	while (n > 0) {
		size_t vl = __riscv_vsetvl_e64m1(n);
		vfloat64m1_t vd = __riscv_vle64_v_f64m1(dst, vl);
		vfloat64m1_t vs = __riscv_vle64_v_f64m1(src, vl);
		vfloat64m1_t vsub =
			__riscv_vfsub_vv_f64m1(vd, __riscv_vfmul_vf_f64m1(vs, factor, vl), vl);
		__riscv_vse64_v_f64m1(dst, vsub, vl);
		dst += vl;
		src += vl;
		n -= vl;
	}
}
