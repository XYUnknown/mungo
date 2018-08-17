package examples.cat;

class CatLinearValid {
	private Cat globalCat = new Cat();

	public CatLinearValid () {
		globalCat.initialise();
	}
	public static void main(String [] args) {
		Cat c1 = new Cat();
		Cat c2 = new Cat();
		c1.initialise();
		c2.initialise();
		Cat c3 = c2;
		c1.playWith(c3);
		c3.poison();
		Cat c4 = new Cat();
		c4.initialise();
		c1.close();
		c3.bury();
		c4.close();
		c2 = new Cat(); // error reported
	}
}