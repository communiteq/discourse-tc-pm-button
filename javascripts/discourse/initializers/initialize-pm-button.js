import { withPluginApi } from 'discourse/lib/plugin-api';
import PmUserButton from "../components/pm-user-button";

export default {
  name: 'extend-for-post-menu-pm-button',
  initialize(container) {

    withPluginApi("1.34.0", (api) => {
      api.registerValueTransformer(
        "post-menu-buttons",
        ({ value: dag, context: { post }}) => {
          dag.add("pm-user", PmUserButton, { before: "reply"});
        }
      );
    });
  }
}