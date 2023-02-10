
document.addEventListener('click', function () {
    console.log('The document was clicked');
});

document.body.addEventListener('click', function () {
    console.log('The body element was clicked');
});



const mainHeading = document.querySelector('h1');

mainHeading.setAttribute('style', 'color: blue; background-color: orange; font-size: 3.5em;');


//Prevent Default
const links = document.querySelectorAll('a');
const thirdLink = links[2];

thirdLink.addEventListener('click', function (event) {
    event.preventDefault();
    console.log("Look, ma! We didn't navigate to a new page!");
});