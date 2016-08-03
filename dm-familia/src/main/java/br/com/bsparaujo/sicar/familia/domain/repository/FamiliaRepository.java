package br.com.bsparaujo.sicar.familia.domain.repository;

import br.com.bsparaujo.framework.ddd.DomainRepository;
import br.com.bsparaujo.sicar.familia.domain.model.Familia;
import br.com.bsparaujo.sicar.familia.domain.model.Pessoa;

import java.util.List;
import java.util.Optional;

public interface FamiliaRepository extends DomainRepository<Familia> {

    /**
     * Obtém as famílias que a pessoa faz parte.
     *
     * @param pessoa Pessoa de referência
     * @return Lista das famílias que a pessoa faz parte.
     */
    List<Familia> listarFamilias(Pessoa pessoa);

    /**
     * Obtém a família onde a pessoa é o cabeça.
     *
     * @param pessoa Pessoa que é o cabeça da família
     */
    Optional<Familia> obterPorCabeca(Pessoa pessoa);
}
