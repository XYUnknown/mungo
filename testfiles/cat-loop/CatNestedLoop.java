package examples.cat;

class CatNestedLoop {
	public static void main(String[] args) {
		Cat cat0 = new Cat();
		cat0.initialise();
		Cat cat1 = new Cat();
		cat1.initialise();
		loop: do {
			cat0.putInBox();
			switch(cat0.openBox()) {
				case FALSE:
					inner0: do {
						cat1.putInBox();
						switch(cat1.openBox()) {
							case TRUE:
								cat1.poison();
								continue inner0;
							case FALSE:
								break inner0;

						}
					} while(true);
					break loop;

				case TRUE:
					inner1: do {
						cat1.putInBox();
						switch(cat1.openBox()) {
							case TRUE:
								cat1.poison();
								continue inner1;
							case FALSE:
								break inner1;
						}
					} while(true);
					cat0.poison();
					continue loop;
			}
		} while(true);

		cat1.bury();
		cat0.bury();
	}
}