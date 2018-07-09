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

	public void close() {

	}

	public static void main(String[] args) {
		Cat c1 = new Cat();
		Cat c2 = new Cat();
		c1.initialise();
		c2.initialise();
		Cat c3 = c2;
		c1.playWith(c2); // Error not detected
		c2.playWith(c1); // Error detected
	}
}