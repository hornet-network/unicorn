# frozen_string_literal: false
use Rack::ContentLength
use Rack::ContentType, "text/plain"
run lambda { |env|

  # our File objects for stderr/stdout should always have #path
  # and stay synchronous and binary across rotation
  ok = $stderr.sync && $stderr.binmode? &&
       $stdout.sync && $stdout.binmode? &&
       String === $stderr.path &&
       String === $stdout.path

  [ 200, {}, [ "#{ok}\n" ] ]
}
