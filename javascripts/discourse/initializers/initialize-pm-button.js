import { withPluginApi } from 'discourse/lib/plugin-api';
import Composer from 'discourse/models/composer';

function shouldShowFor(post, user) {
  return (
    post.topic.archetype == 'regular') &&
    (user?.can_send_private_messages) &&
    (user?.id != post?.user?.id) &&
    (post.topic.archived == false);
}

function initPostMenuPmButton(api) {
  let currentUser = api.getCurrentUser();

  api.addPostMenuButton("pm-user", (attrs) => {
    if (shouldShowFor(attrs, currentUser)) {
      const pmButton = {
        action: "sendPmToUser",
        icon: settings.pm_button_icon,
        title: "post_menu_pm_button.button.title",
        className: "reply create fade-out pm-button-plug-in"
      };
      if (!attrs.mobileView) {
        pmButton.label = themePrefix("pm_button_label");
      }
      return pmButton;
    }
  });

  api.addPostMenuButton("reply-2", (attrs) => {
    // on private messages, the original button is not hidden, so we can use the original one
    if ((attrs.canCreatePost) && (attrs?.topic?.archetype != 'private_message')) {
      const replyButton = {
        action: "replyToPost",
        title: "post.controls.reply",
        icon: settings.reply_button_icon,
        className: "reply create fade-out pm-button-plug-in"
      };
      if (!attrs.mobileView) {
        replyButton.label = themePrefix("reply_button_label");;
      }
      if (shouldShowFor(attrs, currentUser)) {
        replyButton.className += " mmn-no-pull";
      }
      return replyButton;
    }
  });

  api.attachWidgetAction("post-menu", "sendPmToUser", function() {
    this.register.lookup("controller:composer").open({
      action: Composer.PRIVATE_MESSAGE,
      recipients: this.attrs.username,
      archetypeId: 'private_message',
      draftKey: 'new_private_message',
      reply: window.location.protocol + "//" + window.location.host + this.attrs.shareUrl
    });
  });
}

export default {
  name: 'pm-button-tc',
  initialize(_container) {
    withPluginApi('0.1', initPostMenuPmButton);
  }
}

