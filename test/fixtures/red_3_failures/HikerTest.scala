import org.scalatest.funsuite.AnyFunSuite

class HikerTest extends AnyFunSuite {

  test("life the universe and everything") {
    assert(Hiker.answer() == 42)
  }

  test("the answer is odd") {
    assert(Hiker.answer() % 2 == 1)
  }

  test("the hiker is called arthur") {
    assert(Hiker.name() == "arthur")
  }
}
