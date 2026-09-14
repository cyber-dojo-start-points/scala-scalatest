import org.scalatest.funsuite.AnyFunSuite

class HikerTest extends AnyFunSuite {

  ignore("life the universe and everything") {
    assert(Hiker.answer() == 43)
  }

  test("the answer is two digits long") {
    assert(Hiker.answer().toString.length == 2)
  }
}
