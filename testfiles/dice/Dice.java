package examples.dice;

@Typestate("DiceProtocol")
public class Dice {
	public Dice() {

	}

	public void initialise() {

	}

	public void reset() {
		System.out.println("Resetting dice...");
	}

	public void quit() {
		System.out.println("Quitting game...");
	}

	public void cheat() {
		System.out.println("You are cheating...");
	}

	public void close() {
		System.out.println("Closing game...");
	}

	public Side throwDice() {
		int random = (int) (Math.random() * 6 + 1);
		switch(random) {
			case 1:
				return Side.ONE;
			case 2:
				return Side.TWO;
			case 3:
				return Side.THREE;
			case 4:
				return Side.FOUR;
			case 5:
				return Side.FIVE;
			case 6:
				return Side.SIX;
			default:
				return Side.ONE; 
		}
	}
}