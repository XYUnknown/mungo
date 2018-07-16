package examples.cat;

class CatSwitch {
	public static void main(String[] args) {
		Cat cat0 = new Cat();
		Cat cat1 = new Cat();
		cat0.initialise();
		cat0.poison();
		cat1.initialise();
		cat0.putInBox();
		cat1.putInBox();
		BooleanChoice result;
		result = cat1.openBox();
		switch (result) {			
			case FALSE:
				switch (cat0.openBox()){
					case TRUE:
						//cat0.bury();
						cat0.giveBirth();
						break;
					case FALSE:
						cat0.bury();
						break;
				}
				cat1.bury();
				break;
			case TRUE:				
				cat1.giveBirth();
				break;
		} 
	}
}