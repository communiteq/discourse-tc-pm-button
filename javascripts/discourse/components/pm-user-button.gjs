import Component from "@glimmer/component";
import { action } from "@ember/object";
import { get } from "@ember/helper";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { getOwnerWithFallback } from "discourse/lib/get-owner";
import Composer from "discourse/models/composer";
import concatClass from "discourse/helpers/concat-class";
import { i18n } from "discourse-i18n";

export default class PmUserButton extends Component {
  @service site;
  @service composer;
  @service currentUser;

  get mustShow() { // static shouldRender does not get this.currentUser somehow
    return (this.args.post.topic.archetype == 'regular') &&
        this.currentUser &&
        this.currentUser.can_send_private_messages &&
        (this.currentUser.id != this.args.post.user.id) &&
        (this.args.post.topic.archived == false);
  }

  // indicates if the button will be prompty displayed or hidden behind the show more button
  static hidden(args) {
    return false;
  }

  showLabel() {
    return !this.site.isMobileView;
  }

  get pmButtonLabel() {
    return this.site.isMobileView ? "" : themePrefix("pm_button_label");
  }

  get pmButtonIcon() {
    return settings.pm_button_icon;
  }

  get replyButtonLabel() {
    return this.site.isMobileView ? "" : themePrefix("reply_button_label");
  }

  get replyButtonIcon() {
    return settings.reply_button_icon;
  }

  @action
  sendPmToUser() {
    const composerController = getOwnerWithFallback(this).lookup("controller:composer");
    const postUrl = this.args.post?.url;

    composerController.open({
      action: Composer.PRIVATE_MESSAGE,
      draftKey: Composer.NEW_PRIVATE_MESSAGE_KEY,
      draftSequence: 0,
      archetypeId: "private_message",
      title: I18n.t(themePrefix("pm_title"), {
        title: this.args.post?.topic?.title,
      }),
      reply:`${window.location.protocol}//${window.location.host}${postUrl}`,
      recipients: this.args.post.username
    });
  }

  // reply button copied from /app/assets/javascripts/discourse/app/components/post/menu/buttons/reply.gjs

  <template>
    {{#if this.mustShow}}
      <DButton
        class={{concatClass
          "post-action-menu__reply"
          "tc-pm-button"
          "reply"
          (if this.showLabel "create fade-out")
        }}      ...attributes
        @action={{this.sendPmToUser}}
        @icon={{this.pmButtonIcon}}
        @label={{this.pmButtonLabel}}
        @title="post_menu_pm_button.button.title"
      />
      <DButton
        class={{concatClass
          "post-action-menu__reply"
          "tc-pm-button"
          "reply"
          (if this.showLabel "create fade-out")
        }}
        ...attributes
        @action={{@buttonActions.replyToPost}}
        @icon={{this.replyButtonIcon}}
        @label={{this.replyButtonLabel}}
        @title="post.controls.reply"
        @translatedAriaLabel={{i18n
          "post.sr_reply_to"
          post_number=@post.post_number
          username=@post.username
        }}
      />
    {{/if}}
  </template>
}