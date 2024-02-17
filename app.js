const options = ["rock", "paper", "scissor"];
let score = {
  you: 0,
  computer: 0
};
const WIN_GREEN = "#6ac475";
const LOSE_RED = "#c4736a";
const DRAW_BLUE = "#5865f2";

const playerHand = document.querySelector(".hands .player-hand");
const computerHand = document.querySelector(".hands .computer-hand");

function getRandomInt() {
  return Math.floor(Math.random() * 3);
}

const btns = document.querySelectorAll(".options button");
btns.forEach((btn) => {
  btn.addEventListener("click", () => {
    document.querySelector(".hands .player-hand").src = "rock.png";
    document.querySelector(".hands .computer-hand").src = "rock.png";
    playerHand.classList.add('shakePlayer')
    computerHand.classList.add('shakeComputer')
    const playerA = btn.querySelector("label").innerText;
    const playerB = options[getRandomInt()];
    setTimeout(()=>compare(playerA, playerB),1000)
    
  });
});
