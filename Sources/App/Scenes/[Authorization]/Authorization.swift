struct Authorization<T> {
    let resource: T
    let owner: User
    let subject: User?
}
