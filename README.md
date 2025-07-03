# PokemonBox

This project demonstrates basic usage of PokéAPI.

The `PokemonService` uses `URLSession` with Swift's async/await to download a
list of Pokémon and returns their main details:

- `name`
- `flavorText`
- `types`
- `artworkURL`

When the app launches, the main view controller binds to a `MainPageViewModel`,
which uses `PokemonService` to fetch the first page of Pokémon (20 items) and
manages paging and search state. As the user scrolls to the bottom or performs
a search, additional pages are automatically loaded.

See [PokéAPI documentation](https://pokeapi.co/docs/v2) for the REST API
endpoints.

## Next Steps: Modularization

To improve separation of concerns and enable reuse across targets or apps,
consider extracting the Core logic (Models & Services) into a standalone Swift
Package (e.g. `PokemonBoxCore`). This package can then be imported into the
main app (and any other clients) as a dependency.
