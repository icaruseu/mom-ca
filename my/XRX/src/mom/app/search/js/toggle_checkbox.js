
/**easy toggling of checkboxes. If a user deselects all checkboxes by hand, he/she might have to click twice to select all checkboxes again. 
 * But it will be fairly obvious to the user that clicking again will do the trick. 
 * 
 * easy toggle: selection/deselection of all (checkboxes) with the supplied class attribute.
 * @param {String} input_element_id: The id attribute of the input element that triggers the call. (the "clicked" button)
 * @param {String} checkbox_class: The <input> elements (checkboxes) with this class attribute are targeted.
 */



function invert_all_checkboxes(checkbox_class) {

  jQuery("input." + checkbox_class).click();
}

