# Wishlist Domain Layer

The domain layer consists of these components:

  * Model
    * Entities and Values which model the domain of Wishlists.
      * These types also include properties and methods internal to the domain layer.
  * Model Representation
    * Representations of Entities and Values which are used to build the results of Actions.
      * These types do not include any internal properties or methods of the domain layer. Properties included are simple types only.
  * Actors
    * Types which offer methods to call an Action of the domain layer from outside of the domain layer.
  * Actions
    * Types which perform domain specific functionalities on the domain model callable from outside of the domain layer.
  * Services
    * Services providing functionalities of the domain layer which do not belong to a specific Action of the domain layer.
  * Providers
    * Interfaces defining functionalities outside of the domain layer which are used by Actions.

