
paintIt = (element, backgroundColor, textColor) ->
  element.style.backgroundColor = backgroundColor
  if textColor?
    element.style.color = textColor

mosheThis = () ->
  $.ajax(url: "/test").done (html) ->
	  $("#moshe").append html
 
$ ->
  $("select.module").change ->
    backgroundColor = $(this).data("background-color")
    textColor = $(this).data("text-color")
    paintIt(this, backgroundColor, textColor)
    mosheThis()