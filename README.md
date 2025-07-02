# PokemonBox

This project demonstrates basic usage of PokéAPI.

The `PokemonService` uses `URLSession` with Swift's async/await to download a
list of Pokémon and returns their main details:

- `name`
- `flavorText`
- `types`
- `artworkURL`

When the app launches, the main view controller fetches the first page of
Pokémon (20 items) using `PokemonService` and displays them in a list. As the
user scrolls to the bottom, additional pages are automatically loaded.

See [PokéAPI documentation](https://pokeapi.co/docs/v2) for the REST API
endpoints.
