import org.scalatest.funsuite.AnyFunSuite

class FizzBuzzTest extends AnyFunSuite {

  test("three is fizz") {
    assert(FizzBuzz.say(3) == "fizz")
  }
}
