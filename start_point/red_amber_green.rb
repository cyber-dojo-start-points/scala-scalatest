
# ScalaTest ends a run with counts of its own, and those are what decide the
# colour here rather than any of the prose around them.
#
# An assertion that did not hold is a test failing, which is red. Anything else
# that stopped a test is amber: an exception thrown, a match that found no
# case, a call to something that was not there. ScalaTest counts both alike as
# failed, and tells them apart by what it prints underneath. A test that failed
# an assertion gets the message and the line it came from. Anything else gets
# the exception and a stack trace, and it is those stack frames that separate
# the two.

lambda { |stdout,stderr,status|
  output = stdout + stderr

  tests = /^Tests: succeeded \d+, failed (\d+),/.match(output)
  suites = /^Suites: completed \d+, aborted (\d+)$/.match(output)
  total = /^Total number of tests run: (\d+)$/.match(output)

  # No counts at all means nothing ran: a file that would not compile, or a
  # run that died before ScalaTest reached its summary.
  return :amber if tests.nil? || suites.nil? || total.nil?
  # A suite that could not even be built. Its tests were never reached, so
  # nothing here says anything about them.
  return :amber unless suites[1].to_i.zero?
  # Nothing was measured, so there is nothing to be green about.
  return :amber if total[1].to_i.zero?
  return :green if tests[1].to_i.zero?

  # A stack frame, which ScalaTest prints for a throwable it did not raise
  # itself and never for an assertion that did not hold.
  return :amber if /^\s+at \S+\(.*\)$/.match(output)
  :red
}
