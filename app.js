//Update text page content 
const firstHeading=document.querySelector('h1');
firstHeading.innerText='Hello, Register Now with us ';


//Add text page content 
const firstAppend=document.createElement('button');
const textNodeBtn=document.createTextNode('Sign Up');
firstAppend.appendChild(textNodeBtn);
//const addBtn=document.getElementById('addBtn');
firstAppend.setAttribute('class','btn btn-success');
firstAppend.setAttribute('type','button');
firstAppend.style.cssText="color:white; background-color: #77d21d; border: nont; border-radius: 15px; margin: 0px 300px; padding: 0px 25px;";
//addBtn.appendChild(firstAppend);

firstHeading.insertAdjacentElement('afterend',document.body.appendChild(firstAppend));