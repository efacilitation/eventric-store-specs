module.exports =
  runFor: ({StoreClass, initializeCallback}) ->
    describe 'eventric store specs', ->
      store = null

      beforeEach ->
        store = new StoreClass()


      afterEach ->
        sandbox.restore()


      describe '#initialize', ->

        it 'should resolve without an error', ->
          initializePromise = initializeCallback store
          .then ->
            expect(initializePromise).to.be.ok


      describe '#saveDomainEvent', ->

        beforeEach ->
          initializeCallback store


        it 'should save the domain event', ->
          sampleDomainEvent = name: 'SomethingHappened'
          store.saveDomainEvent sampleDomainEvent
          .then ->
            store.findDomainEventsByName 'SomethingHappened', (error, domainEvents) ->
              expect(domainEvents.length).to.equal 1
              expect(domainEvents[0].name).to.equal sampleDomainEvent.name


        it 'should resolve with the saved domain event which has a domain event id', ->
          store.saveDomainEvent {}
          .then (savedDomainEvent) ->
            expect(savedDomainEvent.id).to.be.an.integer


        it 'should assign an ascending integer to each saved domain as id', ->
          saveDomainEventPromises = []
          for i in [0...3]
            saveDomainEventPromises.push store.saveDomainEvent {}
          Promise.all saveDomainEventPromises
          .then (domainEvents) ->
            domainEvents.sort (a, b) -> return a.id - b.id
            domainEvents.map((domainEvent) -> domainEvent.id).forEach (domainEventId, index) ->
              expect(domainEventId).to.equal index + 1


      describe '#findDomainEventsByName', ->

        beforeEach ->
          initializeCallback store


        it 'should call back with domain events with a matching name', (done) ->
          domainEvent = name: 'SomethingHappened'
          store.saveDomainEvent domainEvent
          .then ->
            store.findDomainEventsByName 'SomethingHappened', (error, domainEvents) ->
              expect(domainEvents.length).to.equal 1
              expect(domainEvents[0].name).to.equal domainEvent.name
              done()
          .catch done
          return


        it 'should call back without domain events with another name', (done) ->
          domainEvent = name: 'SomethingElseHappened'
          store.saveDomainEvent domainEvent
          .then ->
            store.findDomainEventsByName 'SomethingHappened', (error, domainEvents) ->
              expect(domainEvents.length).to.equal 0
              done()
          .catch done
          return


        it 'should call back with domain events matching any name given an array of names', (done) ->
          domainEvent1 = name: 'SomethingHappened'
          domainEvent2 = name: 'SomethingElseHappened'
          store.saveDomainEvent domainEvent1
          .then ->
            store.saveDomainEvent domainEvent2
          .then ->
            store.findDomainEventsByName ['SomethingHappened', 'SomethingElseHappened'], (error, domainEvents) ->
              expect(domainEvents.length).to.equal 2
              expect(domainEvents[0].name).to.equal domainEvent1.name
              expect(domainEvents[1].name).to.equal domainEvent2.name
              done()
          .catch done
          return


      describe '#findDomainEventsByAggregateId', ->

        beforeEach ->
          initializeCallback store


        it 'should call back with domain events with a matching aggregate id', (done) ->
          domainEvent = aggregate: id: 42
          store.saveDomainEvent domainEvent
          .then ->
            store.findDomainEventsByAggregateId 42, (error, domainEvents) ->
              expect(domainEvents.length).to.equal 1
              expect(domainEvents[0].name).to.equal domainEvent.name
              done()
          .catch done
          return


        it 'should call back without domain events with another aggregate id', (done) ->
          domainEvent = aggregate: id: 43
          store.saveDomainEvent domainEvent
          .then ->
            store.findDomainEventsByAggregateId 42, (error, domainEvents) ->
              expect(domainEvents.length).to.equal 0
              done()
          .catch done
          return


        it 'should call back with domain events matching any aggregrate id given an array of aggregate ids', (done) ->
          domainEvent1 = aggregate: id: 42
          domainEvent2 = aggregate: id: 43
          store.saveDomainEvent domainEvent1
          .then ->
            store.saveDomainEvent domainEvent2
          .then ->
            store.findDomainEventsByAggregateId [42, 43], (error, domainEvents) ->
              expect(domainEvents.length).to.equal 2
              expect(domainEvents[0].name).to.equal domainEvent1.name
              expect(domainEvents[1].name).to.equal domainEvent2.name
              done()
          .catch done
          return


      describe '#findDomainEventsByNameAndAggregateId', ->

        beforeEach ->
          initializeCallback store


        it 'should call back with domain events with a matching aggregate id and a matching name', (done) ->
          domainEvent =
            name: 'SomethingHappened'
            aggregate: id: 42
          store.saveDomainEvent domainEvent
          .then ->
            store.findDomainEventsByNameAndAggregateId 'SomethingHappened', 42, (error, domainEvents) ->
              expect(domainEvents.length).to.equal 1
              expect(domainEvents[0].name).to.equal domainEvent.name
              done()
          .catch done
          return


        it 'should call back without domain events with another aggregate id or name', (done) ->
          domainEvent1 =
            name: 'SomethingElseHappened'
            aggregate: id: 42
          domainEvent2 =
            name: 'SomethingHappened'
            aggregate: id: 43
          store.saveDomainEvent domainEvent1
          .then ->
            store.saveDomainEvent domainEvent2
          .then ->
            store.findDomainEventsByNameAndAggregateId 'SomethingHappened', 42, (error, domainEvents) ->
              expect(domainEvents.length).to.equal 0
              done()
          .catch done
          return


        it 'should call back with all domain events matching any name and the aggregate id given an array of names', (done) ->
          domainEvent1 =
            name: 'SomethingHappened'
            aggregate: id: 42
          domainEvent2 =
            name: 'SomethingElseHappened'
            aggregate: id: 42
          store.saveDomainEvent domainEvent1
          .then ->
            store.saveDomainEvent domainEvent2
          .then ->
            store.findDomainEventsByNameAndAggregateId ['SomethingHappened', 'SomethingElseHappened'], 42,
            (error, domainEvents) ->
              expect(domainEvents.length).to.equal 2
              expect(domainEvents[0].name).to.equal domainEvent1.name
              expect(domainEvents[1].name).to.equal domainEvent2.name
              done()
          .catch done
          return


        it 'should call back with all domain events matching the name and any aggregate id given an array of ids', (done) ->
          domainEvent1 =
            name: 'SomethingHappened'
            aggregate: id: 42
          domainEvent2 =
            name: 'SomethingHappened'
            aggregate: id: 43
          store.saveDomainEvent domainEvent1
          .then ->
            store.saveDomainEvent domainEvent2
          .then ->
            store.findDomainEventsByNameAndAggregateId 'SomethingHappened', [42, 43], (error, domainEvents) ->
              expect(domainEvents.length).to.equal 2
              expect(domainEvents[0].name).to.equal domainEvent1.name
              expect(domainEvents[1].name).to.equal domainEvent2.name
              done()
          .catch done
          return

