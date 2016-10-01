// drag and drop handlers
// coffeescript doensn't work
// function dragstart_handler(ev) {
//   ev.dataTransfer.setData("text", ev.target.id);
//   ev.dataTransfer.effectAllowed = "move";
// }

// function drop_handler(ev) {
//   ev.preventDefault();
//   var tile = $('#' + ev.dataTransfer.getData("text"));
//   var cel = $(ev.target)
//   // alert(cel.cssInt('width'))
//   // ev.target.appendChild(document.getElementById(data));
//   var new_size = (cel.cssInt('width') - 2).toString() + 'px'
//   cel.css({height: new_size, width: new_size});
//   // alert('sss')
//   cel.append(tile);
// }

// function dragover_handler(ev) {
//   ev.preventDefault();
//   ev.dataTransfer.dropEffect = "move"
// }

// function dragend_handler(ev) {
//   ev.dataTransfer.clearData()
// }

var dragged;

/* events fired on the draggable target */
document.addEventListener("drag", function( event ) {
}, false);

document.addEventListener("dragstart", function( event ) {
  // store a ref. on the dragged elem
  dragged = $(event.target);
  dragged.css('opacity', .5)
}, false);

document.addEventListener("dragend", function( event ) {
  // reset the transparency
  hide_drop_elem($(event.target))
}, false);

/* events fired on the drop targets */
document.addEventListener("dragover", function( event ) {
  // prevent default to allow drop
  event.preventDefault();
}, false);

document.addEventListener("dragenter", function( event ) {
  // highlight potential drop target when the draggable element enters it
  // console.log("dragenter: " + $(event.target).hasClass('board_drop'));
  elem = $(event.target)
  if ( elem.hasClass('board_drop') ) {
    show_drop_elem (elem);
  } else if ( elem.hasClass('shelf_drop') ) {
    show_drop_elem (elem);
  }
}, false);

document.addEventListener("dragleave", function( event ) {
  // reset background of potential drop target when the draggable element leaves it
  elem = $(event.target)
  if ( elem.hasClass('board_drop') ) {
    hide_drop_elem (elem);
  } else if ( elem.hasClass('shelf_drop') ) {
    hide_drop_elem (elem);
  }
}, false);

document.addEventListener("drop", function( event ) {
  // prevent default action (open as link for some elements)
  event.preventDefault();
  elem = $(event.target)
  // move dragged elem to the selected drop target
  if ( elem.hasClass('board_drop') ) {
    letter_resize(dragged, elem);
    hide_drop_elem (elem);
    elem.append(dragged)
  } else   if ( event.target.className == "shelf_drop" ) {
    letter_resize(dragged, elem);
    hide_drop_elem (elem);
    elem.append(dragged)
  }
}, false);

function show_drop_elem(elem) { elem.css('opacity', .5); }
function hide_drop_elem(elem) { elem.css('opacity', ''); }


// letter_resize
function letter_resize(letter, to_elem) {
  var letter_size, points_size, tile_size, tile_width;
  td_width = to_elem.cssInt('width');
  tile_size = (td_width - 2).toString() + 'px';
  letter_size = (td_width * 0.7).toString() + 'px';
  letter.css({
    'height': tile_size,
    'width': tile_size, 
    'line-height': tile_size,
    'font-size': letter_size
  });
  points_size = (td_width * 0.3).toString() + 'px';
  letter.children().css('font-size', points_size);
};