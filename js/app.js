//Build the menu dynamically

let unorderedList = document.getElementById("unordered-list");
let containerCount = document.getElementsByClassName("landing__container")
  .length;

for (i = 1; i < containerCount + 1; i++) {
  let item = "#section" + i + "-title";
  let itemValue = document.querySelector(item);
  let itemText = itemValue.textContent;
  let newLine = document.createElement("li");
  let lineText = document.createTextNode(itemText);
  let listItem = "sample-nav-" + i;
  newLine.setAttribute("id", listItem);
  newLine.setAttribute("class", "nav-list-item");
  newLine.appendChild(lineText);
  unorderedList.appendChild(newLine);

  let itemTarget = document.getElementById("section" + i);
  let listTarget = document.getElementById(listItem);
  let buttonName = "section" + i + "-button";
  let buttonToAdd = document.getElementById(buttonName);

  //Adds button when scrolls into view

  listTarget.addEventListener("click", function() {
    itemTarget.scrollIntoView ({
      behavior: 'smooth'}
    )
//Added behavior smooth as per review. There is now a visible scroll
    buttonToAdd.innerHTML =
      "<button class='section-button' onclick='goToTop()'>Return to Top</button>";
  });
}


//Changed from 'document.documentElement.scrollTop = 0' method to a visible scroll to top as per reviewer


//This is the helper function for a scroll (I set it a bit slow for visibility)
const scrollToTop = () => {
  const scrolling = document.documentElement.scrollTop || document.body.scrollTop;
  if (scrolling > 0) {
    window.requestAnimationFrame(scrollToTop);
    window.scrollTo(0, scrolling - scrolling / 50);
  }
};


// On button click, goes to top of page 
function goToTop() {
scrollToTop();

  for (i = 1; i < containerCount + 1; i++) {
    let buttonToDelete = document.getElementById("section" + i + "-button");
    buttonToDelete.innerHTML = "";
  }
}

//Checks if section is in view and adds active-class with moving background and color change
function checkIfSectionInView() {
  let isInViewport = function(elem) {
    let bounding = elem.getBoundingClientRect();
    return (
      bounding.top <= 50 &&
      bounding.bottom <=
        (window.innerHeight || document.documentElement.clientHeight) &&
      bounding.right <=
        (window.innerWidth || document.documentElement.clientWidth)
    );
  };

  for (i = 1; i < containerCount + 1; i++) {
    let sectionInFullView = document.getElementById("section" + i);

    window.addEventListener(
      "scroll",
      function(event) {
        if (isInViewport(sectionInFullView)) {
          sectionInFullView.classList.add("your-active-class");
        } else {
          sectionInFullView.classList.remove("your-active-class");
        }
      },
      false
    );
  }
}

//Add sticky header as per review (Used tutorial here: https://www.w3schools.com/howto/howto_js_navbar_sticky.asp)

// When the user scrolls the page, execute myFunction
window.onscroll = function() {myFunction()};

// Get the navbar
var navbar = document.getElementById("header");
console.log(navbar)

// Get the offset position of the navbar
var sticky = header.offsetTop;
console.log(sticky)

// Add the sticky class to the navbar when you reach its scroll position. Remove "sticky" when you leave the scroll position
function myFunction() {
  if (window.pageYOffset >= sticky) {
    navbar.classList.add("sticky")
  } else {
    navbar.classList.remove("sticky");
  }
}
checkIfSectionInView();