package br.com.teste.fullstackapi.client.dto;

// Classe para mapear a resposta JSON do ViaCEP
public class ViaCepResponse {
    private String cep;
    private String logradouro;
    private String complemento;
    private String bairro;
    private String localidade; // ViaCEP retorna 'localidade' em vez de 'cidade'
    private String uf;         // E 'uf' em vez de 'estado'
    //private String ibge;
    //private String gia;
    //private String ddd;
    //private String siafi;
    private boolean erro; // ViaCEP retorna erro=true se o CEP for inválido
    
    // Getters e Setters para todos os campos
    public String getCep() { return cep; }
    public void setCep(String cep) { this.cep = cep; }
    public String getLogradouro() { return logradouro; }
    public void setLogradouro(String logradouro) { this.logradouro = logradouro; }
    public String getComplemento() { return complemento; }
    public void setComplemento(String complemento) { this.complemento = complemento; }
    public String getBairro() { return bairro; }
    public void setBairro(String bairro) { this.bairro = bairro; }
    public String getLocalidade() { return localidade; }
    public void setLocalidade(String localidade) { this.localidade = localidade; }
    public String getUf() { return uf; }
    public void setUf(String uf) { this.uf = uf; }
    public boolean isErro() { return erro; }
    public void setErro(boolean erro) { this.erro = erro; }
    // ... getters e setters para os outros campos se precisar ...
}