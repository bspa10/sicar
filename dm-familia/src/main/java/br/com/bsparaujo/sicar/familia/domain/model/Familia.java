package br.com.bsparaujo.sicar.familia.domain.model;

import br.com.bsparaujo.datatype.Nome;
import br.com.bsparaujo.framework.ddd.AgregateRoot;
import br.com.bsparaujo.framework.ddd.DomainEntity;
import br.com.bsparaujo.sicar.familia.domain.exception.FamiliaException;
import lombok.AccessLevel;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Configurable;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Data
@Configurable
@Setter(AccessLevel.PACKAGE)
public final class Familia implements AgregateRoot, DomainEntity {

    @Getter(AccessLevel.NONE)
    @Setter(AccessLevel.PACKAGE)
    private Long id;
    private final Nome nome;
    private final Pessoa cabeca;
    private final List<Pessoa> membros = new ArrayList<>();

    @Autowired
    @Getter(AccessLevel.NONE)
    @Setter(AccessLevel.NONE)
    private FamiliaInternalRepository familiaRepository;

    /**
     * Cria uma nova família no sistema.
     *
     * @param cabeca Cabeça da família
     * @param nome Nome da família
     * @return Família que foi criada
     */
    public static Familia of(final Pessoa cabeca, final Nome nome) {
        return new Familia(cabeca, nome);
    }

    private Familia(final Pessoa cabeca, final Nome nome) {
        if (nome == null || cabeca == null) {
            throw new FamiliaException("A família deve ter um nome e um cabeça.");
        }

        this.nome = nome;
        this.cabeca = cabeca;
    }

    /**
     * Lista de todos os membros da família.
     *
     * <p>
     *     Não existe nenhuma ordem em particular para a lista retornada.
     * </p>
     *
     * @return Lista de todos os membros da família
     */
    public List<Pessoa> membros() {
        return membros;
    }

    /**
     * Adiciona a pessoa a família.
     */
    public void adicionar(final Pessoa pessoa) {
        if (membros.contains(pessoa)) {
            throw new FamiliaException("A pessoa já faz parte da família.");
        }

        membros.add(pessoa);
        familiaRepository.adicionarMembro(this, pessoa);
    }

    /**
     * Remove a pessoa da família.
     *
     * @param pessoa Pessoa que será remvida
     */
    public void remover(final Pessoa pessoa) {
        if (ehCabeca(pessoa)) {
            throw new FamiliaException("Não é possível remover o cabeça.");
        }

        membros.remove(pessoa);
        familiaRepository.removerMembro(this, pessoa);
    }

    /**
     * Identifica se a pessoa é o cabeça da família.
     *
     * @param pessoa Pessoa a ser verificada
     * @return <code>true</code> se a pessoa for o cabeça da família, <code>false</code> caso contrário
     */
    public boolean ehCabeca(Pessoa pessoa) {
        return cabeca.getEmail().equals(pessoa.getEmail());
    }

    @Override
    public Optional<Long> identidade() {
        return id == null ? Optional.empty() : Optional.of(id);
    }
}
