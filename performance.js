

//Usining perfomance.now() to measure the time of a code
const startingTime = performance.now();

for (let i = 1; i <= 100; i++) { 
  for (let j = 1; j <= 100; j++) {
    console.log('i and j are ', i, j);
  } 
} 

const endingTime = performance.now(); 
console.log('Este código levou ' + (endingTime - startingTime) + ' milliseconds.');


/*
    Using performance to compare the performance of two codes
*/

// this code is faster
const t0 = performance.now();
const myCustomDiv = document.createElement('div');

for (let i = 0; i <= 200; i++) {
    const newElement = document.createElement('p');
    newElement.innerText = 'This is paragraph number ' + i;

    myCustomDiv.appendChild(newElement);
}

document.body.appendChild(myCustomDiv);

const t1 = performance.now();
console.log('This code took ' + (t1 - t0) + ' milliseconds.');

// this code is slower
const t2 = performance.now();
for (let i = 0; i <= 200; i++) {
    const newElement = document.createElement('p');
    newElement.innerText = 'This is paragraph number ' + i;

    document.body.appendChild(newElement);
}

const t3 = performance.now();
console.log('This code took ' + (t3 - t2) + ' milliseconds.');

// this code is THE FASTEST
const t4 = performance.now();
const fragment = document.createDocumentFragment(); // ← usa um DocumentFragment em vez de uma <div>

for (let i = 0; i < 200; i++) { 
    const newElement = document.createElement('p'); 
    newElement.innerText = 'This is paragraph number ' + i;

    fragment.appendChild(newElement); 
} 

document.body.appendChild(fragment);

const t5 = performance.now();
console.log('This code took ' + (t5 - t4) + ' milliseconds.');

/*
    The Call Stack
*/

function addParagraph() {
    const para = document.createElement('p');
    para.textContent = 'JavaScript is single threaded!';

    appendNewMessage();
    document.body.appendChild(para);
}

function appendNewMessage() {
    const para = document.createElement('p');

    para.textContent = "Isn't that cool?";
    document.body.appendChild(para);
}

addParagraph();

/* 
    The Event Loop
*/

console.log('howdy');
document.addEventListener('click', function numbers() {
    console.log('123');
});
console.log('ice cream is tasty');

/*
    SetTimeout
*/

// this code will print 'Howdy' after 1 second
setTimeout(function sayHi() {
    console.log('Howdy');
}, 1000);

// this code will print 'Howdy' after 0 seconds
//this technique can help us to convert potentially long-running code to one that's broken up to allow for the browser to handle user interactions!
setTimeout(function sayHi() {
    console.log('Howdy');
}, 0);  // ← 0 milliseconds!


/* 
    This code starts off by setting a count variable to 1. This will keep track of the number of paragraphs that have been added. 
    The generateParagraphs() function will add 500 paragraphs to the page each time it's invoked. 
    The interesting thing is that there's a setTimeout() call at the end of the generateParagraphs() function. 
    If there are less than twenty thousand elements, then the setTimeout() will be used to call the generateParagraphs() function.
*/
let count = 1

function generateParagraphs() {
    const fragment = document.createDocumentFragment();

    for (let i = 1; i <= 500; i++) {
        const newElement = document.createElement('p');
        newElement.textContent = 'This is paragraph number ' + count;
        count = count + 1;

        fragment.appendChild(newElement);
    }

    document.body.appendChild(fragment);

    if (count < 20000) {
        setTimeout(generateParagraphs, 0);
    }
}

generateParagraphs();

