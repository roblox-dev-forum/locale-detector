import { ajax } from "discourse/lib/ajax";
import KeyValueStore from "discourse/lib/key-value-store";

const localeDetectorStore = new KeyValueStore("locale-detector");

export default {
	setupComponent() {
		this.set("hidden", true);
		this.set("language", null);
		if(this.currentUser !== undefined) {
			this.set("username", this.currentUser.get("username"));
		}

		if(!localeDetectorStore.get("hidden")) {
			ajax("/site/locale-detector.json").then(lang => {
				if(lang !== null) {
					this.set("language", lang.language);
					this.set("hidden", false);
				}
			});
		}
	},

	actions: {
		dismiss() {
			localeDetectorStore.set({ hidden: true });
			this.set("hidden", true);
			ajax("/site/locale-detector.json", { type: "POST" })
		},
	},
};
