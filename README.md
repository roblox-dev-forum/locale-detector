# Plugin: `locale-detector`

Prompts users with a suggestion to change their forum locale to that of their browser.

---

## Features

- When the user currently has the default forum locale, but their browser is in a different locale that is supported by Discourse, a banner will apear on the forum prompting the user with a suggestion to change their forum locale to match their browser locale.

  - The banner will appear until the user changes their locale to something other than the default, or dismisses the banner, after which it should not show up again for that user.

---

## Impact

### Community

Forum users will be more likely to set their forum locale to match one that is appropriate for their viewing experience. They are less likely to miss the setting to change their locale.

This makes the forum more accessible for a portion of international users that prefers to have the forum functionality localized in their native language rather than English.

### Internal

No effect.

### Resources

There is a little bit more network traffic back and forth to determine whether the user should be shown a banner whenever they start a new forum session. This should cause only a small performance impact that will likely not be noticeable.

### Maintenance

Developer Relations should translate, and maintain translations of, the message that appears on the modal for the different locales of the communities that are supported on the Developer Forum.

---

## Technical Scope

The standard recommended functionality is used to add a custom field type to user objects, which represent whether the user has seen / dismissed the modal that suggests changing the forum locale.

A rails engine is defined to create new endpoints that can be used by the plugin. Standard functionality is used to route the endpoints to the right methods in the engine. The custom user field type is used and set by these endpoints to determine what language to return and to make sure the user stops seeing the banner after changing their locale or dismissing the banner.

To find out what locale to suggest to the user, the endpoint compares the user's browser's locale as known to the server with the list of officially supported locales, and picks the matching option from that list if it exists.
