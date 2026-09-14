import org.scalatest.funsuite.AnyFunSuite

class AnswerSizeTest extends AnyFunSuite {

  test("the answer is three digits long") {
    assert(Hiker.answer().toString.length == 3)
  }
}
