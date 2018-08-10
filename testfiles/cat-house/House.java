package examples.cat;

@Typestate("HouseProtocol")
public class House {
	private Cat c;

	public House() {

	}

	public void createCat() {
		c = new Cat();
	}

	public void killCat() {
		c.giveBirth();
		c.poison();
		System.out.println("Your cat is killed");
	}

	public void close() {
		c.close();
	}
}