//
//  ScreenFactory+Login.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/7/26.
//

extension ScreenFactory {

    func makeLoginViewController() -> LoginViewController {
        let signInService: SignInService = container.resolve()
        let authRepository: AuthRepository = container.resolve()
        let userRepository: UserRepository = container.resolve()
        let useCase = SignInUseCase(
            signInService: signInService,
            authRepository: authRepository,
            userRepository: userRepository
        )
        let viewModel = LoginViewModel(signInUseCase: useCase)
        return LoginViewController(viewModel: viewModel)
    }

}
