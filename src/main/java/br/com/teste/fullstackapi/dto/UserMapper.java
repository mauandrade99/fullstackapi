package br.com.teste.fullstackapi.dto;

import br.com.teste.fullstackapi.model.User;

public class UserMapper {

    public static UserResponseDTO toDTO(User user) {
        if (user == null) {
            return null;
        }
        return new UserResponseDTO(
            user.getId(),
            user.getNome(),
            user.getEmail(),
            user.getRole()
        );
    }
}