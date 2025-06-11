// src/main/java/br/com/teste/fullstackapi/client/ViaCepClient.java
package br.com.teste.fullstackapi.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import br.com.teste.fullstackapi.client.dto.ViaCepResponse;

@FeignClient(name = "viacep", url = "https://viacep.com.br/ws")
public interface ViaCepClient {

    @GetMapping("/{cep}/json/")
    ViaCepResponse getEnderecoByCep(@PathVariable("cep") String cep);
}