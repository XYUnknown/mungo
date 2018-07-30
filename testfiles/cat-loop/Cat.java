package examples.cat;

@Typestate("CatProtocol")
public class Cat {
	private int life = -1;

	public Cat(){

	}

	public void initialise() {
		this.life = 1;
	}

	public void poison() {
		this.life = 0;
	}

	public void playWith(Cat c) {
		System.out.println("Cats are playing...");
	}

	public void putInBox() {
		System.out.println("Put cat in box...");
	}

	public 	BooleanChoice openBox() {
		if(this.life == 0){
			return BooleanChoice.FALSE;
		}
		return BooleanChoice.TRUE;
	}

	public Cat giveBirth() {
		return new Cat();
	}

	public void bury() {
		System.out.println("This cat is buried");
	}

	public void close() {

	}
}