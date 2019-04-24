
function flip(event) {
    var wl_item_card = event.target.closest(".wl-item-card");
    if (wl_item_card) {
        wl_item_card.classList.toggle("flipped");
    }
}

document.addEventListener('DOMContentLoaded', function() {
    if (document.body.id == "wishlist") {
        for (var wl_item_btn_flip of document.querySelectorAll('.wl-item-btn-flip')) {
            wl_item_btn_flip.addEventListener('click', flip, false);
        }
    }
});
