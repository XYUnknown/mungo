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

	public static void main(String[] args) {
		Cat c1 = new Cat();
		Cat c2 = new Cat();
		c1.initialise();
		c2.initialise();
		Cat c3 = c2;
		c1.playWith(c2); // Error detected
		c2.playWith(c1); // Error detected
		c1.playWith(c3); // pass
		c3.poison();
		c1.playWith(c3); // Error detected
		Cat c4 = new Cat();
		c4.initialise();
		c4.putInBox();
		c1.playWith(c4); // Error detected
		c4.playWith(c1); // Error detected

		// Test sequence  method access
		Cat cat0 = new Cat();
		cat0.initialise();
		cat0.giveBirth().poison(); // Error detected

		// Test sequence method access
		Cat cat00 = new Cat();
		cat00.initialise();
		cat00.giveBirth().initialise(); // pass

		// Test Assignment using Dot
		Cat neko0 = new Cat();
		neko0.initialise();
		Cat neko1 = neko0.giveBirth();
		neko1.initialise(); // pass
		neko1.openBox(); // Error detected
		Cat neko2;
		neko2 = neko0.giveBirth();
		neko2.initialise();


		// Switch statement
		Cat cat1 = new Cat();
		cat1.initialise();
		cat1.putInBox();
		switch (cat1.openBox()) {
			case TRUE:				
				cat1.giveBirth();
				//cat1.bury();
				break;
			case FALSE:
				cat1.bury();
				break;
		}
	}
}