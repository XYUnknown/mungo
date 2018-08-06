package examples.dice;

class DiceGame {

	public static void main(String [] args) {
		Dice d = new Dice();
		d.initialise();
		loop: do {
			switch(d.throwDice()) {
				case ONE:
					d.reset();
					continue loop;
				case TWO:
					d.reset();
					continue loop;
				case THREE:
					d.reset();
					continue loop;
				case FOUR:
					d.cheat();
					break loop;
				case FIVE:
					d.reset();
					continue loop;
				case SIX:
					break loop;
			}
		} while(true);

		d.close();
	}	
}