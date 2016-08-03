package br.com.bsparaujo.sicar.familia.domain.event;

import br.com.bsparaujo.framework.ddd.DomainEvent;
import br.com.bsparaujo.sicar.familia.domain.model.Familia;
import lombok.*;

@Data
@Setter(AccessLevel.PACKAGE)
@EqualsAndHashCode(callSuper = true)
public class FamiliaEvent extends DomainEvent {

    @Getter(AccessLevel.PROTECTED)
    private Familia familia;

}
