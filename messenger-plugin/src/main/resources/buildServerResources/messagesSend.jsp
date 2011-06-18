<%@ include file="/include.jsp" %>

<%-- MessagesSendExtension.fillModel() --%>
<jsp:useBean id="groups"  scope="request" type="java.util.Collection"/>
<jsp:useBean id="users"   scope="request" type="java.util.Collection"/>
<jsp:useBean id="action"  scope="request" type="java.lang.String"/>


<style type="text/css">
    .ui-dialog-titlebar{ display: none } /* Hiding dialog title */
</style>
<script type="text/javascript">

    var j            = jQuery
    var messagesSend = {

       /**
        * Opens the dialog with message specified
        */
        dialog : function( message )
        {
            j( '#messages-send-dialog-text' ).text( message );
            j( '#messages-send-dialog'      ).dialog({ height : 55,
                                                       width  : 230,
                                                       close  : messagesSend.dialogClose });
        },
        /**
         * Closes the dialog and enables "Send" button
         */
        dialogClose : function()
        {
            j( '#messages-send-dialog' ).dialog( 'destroy' );
            j( '#messages-message'     ).val( '' ).focus();
            j( '#messages-send'        ).attr({ disabled: null });
        }
    };

    j( function() {

        j( '#messages-message' ).focus();

       /**
        * "Message Sent" Ok button listener
        */
        j( '#messages-send-dialog-ok' ).click( function(){ messagesSend.dialogClose(); return false; });

       /**
        * Listener enabling and disabling groups and users according to "Send to All" checkbox
        */
        j( '#messages-all' ).change( function() {
            j( '#messages-groups' ).attr({ disabled: this.value });
            j( '#messages-users'  ).attr({ disabled: this.value });
        });

       /**
        * Listener submitting a request when form is submitted
        */
        j( '#messages-form' ).submit( function() {

            if ( ! j.trim( j( '#messages-message' ).val()))
            {
                j( '#messages-message'      ).addClass( 'errorField'   );
                j( '#messages-errormessage' ).text( 'Message is empty' );
                return false;
            }
            else
            {
                j( '#messages-message' ).removeClass( 'errorField' );
                j( '#messages-errormessage' ).text( '' );
            }

            var    recipientsSelected = ( j( '#messages-all'    ).attr( 'checked' ) ||
                                          j( '#messages-groups' ).val()          ||
                                          j( '#messages-users'  ).val());
            if ( ! recipientsSelected )
            {
                j( '#messages-errorselection' ).text( 'No recipients selected' );
                return false;
            }
            else
            {
                j( '#messages-errorselection' ).text( '' );
            }

            j( '#messages-send'     ).attr({ disabled: 'disabled' });
            j( '#messages-progress' ).show();

            j.ajax({ url      : this.action,
                     type     : 'POST',
                     data     : j( this ).serialize(),
                     dataType : 'text',  
                     success  : function( response ) { messagesSend.dialog( 'Message "' + response + '" was sent' )},
                     error    : function()           { messagesSend.dialog( 'Failed to send the message' )},
                     complete : function()           { j( '#messages-progress' ).hide()}
                    });

            return false;
        });
    })
</script>


<div id="messages-send-dialog" style="display:none; overflow:hidden;">
	<p>
		<span class="ui-icon ui-icon-circle-check" style="float:left; margin:0 7px 50px 0;"></span>
        <span id="messages-send-dialog-text"></span>
        <a id="messages-send-dialog-ok" href="#" class="text-link" style="margin-left: 15px">Ok</a>
	</p>
</div>

<div class="settingsBlock" style="">
    <div style="background-color:#fff; padding: 10px;">
        <form action="${action}" method="post" id="messages-form">

            <p>
                <label for="messages-urgency">Urgency: </label>
                <select name="urgency" id="messages-urgency">
                    <option selected="selected">Info</option>
                    <option>Warning</option>
                    <option>Critical</option>
                </select>
            </p>

            <p>
                <label for="messages-longevity-number">Keep For: </label>
                <input class="textfield1" id="messages-longevity-number" name="longevity-number" type="text" size="3"
                       maxlength="3" value="7">
                <select id="messages-longevity-unit" name="longevity-unit">
                    <option>hours</option>
                    <option selected="selected">days</option>
                    <option>weeks</option>
                    <option>months</option>
                </select>
            </p>

            <p><label for="messages-message">Message: <span class="mandatoryAsterix" title="Mandatory field">*</span></label>
                <textarea class="textfield" id="messages-message" name="message" cols="30" rows="12"></textarea>
                <span class="error" id="messages-errormessage" style="margin-left: 10.5em;"></span>
            </p>

            <p><label for="messages-all">Send to All:</label>
                <input style="margin:0" type="checkbox" id="messages-all" name="all" checked="checked">
            </p>

            <p>
                <label for="messages-groups">Send to Groups:</label>
                <select id="messages-groups" name="groups" multiple="multiple" size="2" disabled="disabled">
                <c:forEach items="${groups}" var="group">
                    <option>${group}</option>
                </c:forEach>
                </select>
            </p>

            <p>
                <label for="messages-users">Send to Users:</label>
                <select id="messages-users" name="users" multiple="multiple" size="2" disabled="disabled">
                <c:forEach items="${users}" var="user">
                    <option>${user}</option>
                </c:forEach>
                </select>
                <span class="error" id="messages-errorselection" style="margin-left: 10.5em;"></span>
            </p>

            <p>
                <input type="submit" value="Send" id="messages-send"> <img id="messages-progress" src="${teamcityPluginResourcesPath}images/ajax-loader.gif" style="display: none"/>
            </p>
        </form>
    </div>
</div>
