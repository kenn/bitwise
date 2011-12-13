#include <ruby.h>

VALUE BitwiseClass;

static int COUNT_TABLE[] = {
  0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4,
  1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
  1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
  2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
  1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
  2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
  2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
  3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
  1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
  2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
  2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
  3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
  2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
  3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
  3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
  4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8,
};

static VALUE bw_population_count(VALUE self, VALUE str) {
  int count, i;
  unsigned char *buffer = RSTRING_PTR(str);
  count = 0;
  for (i = 0; i < RSTRING_LEN(str); i++) {
    count += COUNT_TABLE[buffer[i]];
  }
  return INT2NUM(count);
}

static VALUE bw_string_not(VALUE self, VALUE str)
{
  VALUE result = rb_str_new(RSTRING_PTR(str), RSTRING_LEN(str));
  int i;
  for (i = 0; i < RSTRING_LEN(str); i++) {
    RSTRING_PTR(result)[i] = ~RSTRING_PTR(str)[i];
  }
  return result;
}

static VALUE bw_string_union(VALUE self, VALUE max, VALUE min)
{
  VALUE result = rb_str_new(RSTRING_PTR(max), RSTRING_LEN(max));
  int i;
  for (i = 0; i < RSTRING_LEN(min); i++) {
    RSTRING_PTR(result)[i] |= RSTRING_PTR(min)[i];
  }
  return result;
}

static VALUE bw_string_intersect(VALUE self, VALUE max, VALUE min)
{
  VALUE result = rb_str_new(RSTRING_PTR(min), RSTRING_LEN(min));
  int i;
  for (i = 0; i < RSTRING_LEN(min); i++) {
    RSTRING_PTR(result)[i] &= RSTRING_PTR(max)[i];
  }
  return result;
}

static VALUE bw_string_xor(VALUE self, VALUE max, VALUE min)
{
  VALUE result = rb_str_new(RSTRING_PTR(max), RSTRING_LEN(max));
  int i;
  int min_len = RSTRING_LEN(min);
  for (i = 0; i < RSTRING_LEN(max); i++) {
    RSTRING_PTR(result)[i] ^= ((i < min_len) ? RSTRING_PTR(min)[i] : 0);
  }
  return result;
}

void Init_bitwise()
{
  BitwiseClass = rb_define_class("Bitwise", rb_cObject);
  rb_define_singleton_method(BitwiseClass, "population_count", bw_population_count, 1);
  rb_define_singleton_method(BitwiseClass, "string_not", bw_string_not, 1);
  rb_define_singleton_method(BitwiseClass, "string_union", bw_string_union, 2);
  rb_define_singleton_method(BitwiseClass, "string_intersect", bw_string_intersect, 2);
  rb_define_singleton_method(BitwiseClass, "string_xor", bw_string_xor, 2);
}
