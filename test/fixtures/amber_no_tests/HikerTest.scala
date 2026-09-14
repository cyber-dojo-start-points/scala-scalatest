import org.scalatest.funsuite.AnyFunSuite

class HikerTest extends AnyFunSuite {

  def lifeTheUniverseAndEverything(): Unit = {
    assert(Hiker.answer() == 42)
  }
}
