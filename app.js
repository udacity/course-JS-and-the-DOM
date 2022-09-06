const startBtnEL = document.getElementById('start-now');
startBtnEL.style.background = '#2015ff';
startBtnEL.style.borderRadius = '5rem';
const heroHomepageEL = document.querySelector('.hero--homepage')
heroHomepageEL.classList.add('new-hero')
const cardsEL = document.querySelectorAll('.card')
// console.log(cardsEL);
cardsEL.forEach((cardEL) => {
    cardEL.classList.add('new-card')
});

// function removeLastProg() {
//     featuredProgramsEL.lastElementChild.remove()
//     document.removeEventListener('click', removeLastProg)
// }
// const featuredProgramsEL = document.querySelector('.hero__module');

// const removeLastProg = event => {
// featuredProgramsEL.lastElementChild.remove()
// document.removeEventListener('click', removeLastProg)
// console.log('event', event);
// }
// document.addEventListener('click', removeLastProg)

// ----------------------ex 29----------------------//


const favProgramsEL = document.querySelectorAll('.card__container')
// console.log(favProgramsEL); found the ELcards
function toggleAddRemoveFav(addToFavBtnEL, favIndicator) {
    console.log(addToFavBtnEL.textContent);
    // let isFav = addToFavBtnEL.textContent === 'remove from favs'
    let isFav = !addToFavBtnEL.classList.toggle('currFav')
    console.log(isFav);
    if (!isFav) {
        addToFavBtnEL.textContent = 'remove from favs'

        favIndicator.textContent = '🌟🌟🌟'
        addToFavBtnEL.appendChild(favIndicator)
    } else {
        favIndicator.remove()
        addToFavBtnEL.textContent = 'add to favs'
    }
}


favProgramsEL.forEach(favProgramEL => {
    const addToFavBtnEL = document.createElement('button')
    const favIndicator = document.createElement('p')
    addToFavBtnEL.classList.add('add-rem-fav')
    addToFavBtnEL.textContent = 'add to favs'
    addToFavBtnEL.addEventListener('click', function toggleFav(e) {
        e.preventDefault();
        toggleAddRemoveFav(addToFavBtnEL, favIndicator)
    })

    const favProgramTitleEL = favProgramEL.querySelector('.card--nanodegree__title')
    // console.log(favProgramsTitleEL);
    favProgramTitleEL.appendChild(addToFavBtnEL)


});



// (function() {
//     var btn = document.createElement("button"),
//         c = document.createElement("style");
//     c.textContent = `
//         .btn-favorite {
//             margin: 0 auto;
//             background: #6cf;
//             border: 2px solid #09c;
//         }
//         .favorite-course {
//             background: #ffe;
//         }
//         .favorite-course h4::before {\
//             content: ":star: ";
//         }
//     `;
//     document.head.appendChild(c);
//     btn.className = "btn-favorite";
//     btn.textContent = "Add to Favorites";
//     document.querySelectorAll(".card--nanodegree__title").forEach(function(a) {
//         a.appendChild(btn.cloneNode(true));
//     });
//     document.addEventListener("click", function(e) {
//         let b = e.target,
//             isFav;
//         if (b.classList.contains("btn-favorite")) {
//             e.preventDefault();
//             isFav = b.classList.toggle("is-favorite");
//             if (isFav) {
//                 b.textContent = "Remove from Favorites";
//                 b.parentNode.parentNode.classList.add("favorite-course");
//             } else {
//                 b.textContent = "Add to Favorites";
//                 b.parentNode.parentNode.classList.remove("favorite-course");
//             }
//         }
//     });
// }());