# -*- encoding: binary -*-
# frozen_string_literal: false
require 'mkmf'

# This fork commits the Ragel-generated parser. Without it the extension
# builds but has no Init_unicorn_http. It is not generated here because
# Ragel on arm64 Linux emits a different state machine than on x86-64.
unless File.exist?(File.expand_path('unicorn_http.c', __dir__))
  abort 'ext/unicorn_http/unicorn_http.c is missing: regenerate it with ' \
        '`gmake ragel` on x86-64 and commit it'
end

have_func("rb_hash_clear", "ruby.h") or abort 'Ruby 2.0+ required'

message('checking if String#-@ (str_uminus) dedupes... ')
begin
  a = -(%w(t e s t).join)
  b = -(%w(t e s t).join)
  if a.equal?(b)
    $CPPFLAGS += ' -DSTR_UMINUS_DEDUPE=1 '
    message("yes\n")
  else
    $CPPFLAGS += ' -DSTR_UMINUS_DEDUPE=0 '
    message("no, needs Ruby 2.5+\n")
  end
rescue NoMethodError
  $CPPFLAGS += ' -DSTR_UMINUS_DEDUPE=0 '
  message("no, String#-@ not available\n")
end

message('checking if Hash#[]= (rb_hash_aset) dedupes... ')
h = {}
x = {}
r = rand.to_s
h[%W(#{r}).join('')] = :foo
x[%W(#{r}).join('')] = :foo
if x.keys[0].equal?(h.keys[0])
  $CPPFLAGS += ' -DHASH_ASET_DEDUPE=1 '
  message("yes\n")
else
  $CPPFLAGS += ' -DHASH_ASET_DEDUPE=0 '
  message("no, needs Ruby 2.6+\n")
end

if have_func('epoll_create1', %w(sys/epoll.h))
  have_func('rb_io_descriptor') # Ruby 3.1+
end
create_makefile("unicorn_http")
