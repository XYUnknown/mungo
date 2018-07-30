package examples.cat;

class CatLoop {
	public static void main(String[] args) {
		Cat cat0 = new Cat();
		cat0.initialise();
		loop: do {
			cat0.putInBox();
			switch(cat0.openBox()) {
				case FALSE:
					break loop;

				case TRUE:
					cat0.poison();
					continue loop;
			}
		} while(true);

		cat0.bury();
	}
}