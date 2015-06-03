
/**easy toggling of checkboxes. If a user deselects all checkboxes by hand, he/she might have to click twice to select all checkboxes again. 
 * But it will be fairly obvious to the user that clicking again will do the trick. 
 * 
 * easy toggle: selection/deselection of all (checkboxes) with the supplied class attribute.
 * @param {String} input_element_id: The id attribute of the input element that triggers the call. (the "clicked" button)
 * @param {String} checkbox_class: The <input> elements (checkboxes) with this class attribute are targeted.
 */
function de_select_all_checkboxes(input_element_id, checkbox_class) {
	jQuery("#" + input_element_id).toggleClass("none_selected");
    if(jQuery("#" + input_element_id).hasClass("none_selected")){
      jQuery("input." + checkbox_class).prop("checked", false);
    }
    else{
      jQuery("input." + checkbox_class).prop("checked", true);
    }
}