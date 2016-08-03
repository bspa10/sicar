package br.com.bsparaujo.sicar.familia.domain.model;

import br.com.bsparaujo.datatype.Documento;
import br.com.bsparaujo.datatype.Email;
import br.com.bsparaujo.datatype.Nome;
import br.com.bsparaujo.datatype.TipoDocumento;
import br.com.bsparaujo.framework.ddd.AgregateRoot;
import br.com.bsparaujo.framework.ddd.DomainEntity;
import br.com.bsparaujo.sicar.familia.domain.exception.FamiliaException;
import lombok.AccessLevel;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Configurable;

import java.util.Optional;

@Data
@Configurable
@Setter(AccessLevel.NONE)
public final class Pessoa implements AgregateRoot, DomainEntity {

    @Getter(AccessLevel.NONE)
    @Setter(AccessLevel.PACKAGE)
    private Long id;
    private final Nome nome;
    private final Documento documento;
    private final Email email;

    @Autowired
    private PessoaInternalRepository pessoaRepository;

    /**
     * Cria uma nova pessoa no sistema.
     *
     * @param documento Documento de identificação da pessoa
     * @param nome Nome da pessoa
     * @param email E-mail da pessoa
     * @return pessoa que foi criada
     */
    public static Pessoa of(final Documento documento, final Nome nome, final Email email) {
        return new Pessoa(documento, nome, email);
    }

    private Pessoa(final Documento documento, final Nome nome, final Email email) {
        if (nome == null || documento == null || email == null) {
            throw new FamiliaException("A pessoa deve ter nome, documento, e endereço de e-mail");
        }

        if (documento.getTipoDocumento() == TipoDocumento.CNPJ) {
            throw new FamiliaException("Uma pessoa não pde ter CNPJ");
        }

        this.nome = nome;
        this.documento = documento;
        this.email = email;
    }

    @Override
    public Optional<Long> identidade() {
        return id == null ? Optional.empty() : Optional.of(id);
    }

    public Pessoa atualizar(final Documento documento, final Nome nome, final Email email) {
        return pessoaRepository.atualizar(this, documento, nome, email);
    }

}
