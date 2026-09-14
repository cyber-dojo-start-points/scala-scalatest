import org.scalatest.funsuite.AnyFunSuite

class HikerTest extends AnyFunSuite {

  test("life the universe and everything") {
    for (i <- 0 until 20000) {
      println("debug: i is " + i)
    }
    assert(Hiker.answer() == 42)
  }
}
