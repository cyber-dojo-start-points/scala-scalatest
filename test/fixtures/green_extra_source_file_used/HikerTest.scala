import org.scalatest.funsuite.AnyFunSuite

class HikerTest extends AnyFunSuite {

  test("life the universe and everything") {
    assert(Hiker.answer() == 42)
  }

  test("the answer is two digits long") {
    assert(Digits.count(Hiker.answer()) == 2)
  }
}
