#getModuleForm = ( module ) ->
#	$(".collapse").collapse('hide')
#	$("##{module}").collapse('show')


getModuleForm = ( module, project ) ->
  $.ajax(url: "/extensions/#{project}/#{module}", dataType: 'html').done (html) ->
	  $("#module-form").html html

refreshPage = (amt=90000) ->
	setTimeout (->
	  location.reload 1
	), amt
 
$ ->
	$("select.module").change ->
		module = $(this).val()
		project = $(this).attr('id')
		getModuleForm( module, project )
		
	$(".refresh-button").click ->
		refreshPage(1000)
			
	$(document).ready ->
		if $(".refresh-button").data('state')
			$(".refresh-button").button('toggle')
			refreshPage()