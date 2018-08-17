package examples.cat;

@Typestate("HouseProtocol")
public class House {
	private Cat c;

	public House() {

	}

	public void killCat() {
		c.giveBirth(); // error reported
		c.poison();
		System.out.println("Your cat is killed");
	}

	public void createCat() {
		c = new Cat();
		c.initialise();
	}

	public void close() {
		c.close(); // error reported
	}
}